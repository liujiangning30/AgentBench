import contextlib
import time
import warnings
import traceback
import sys
from copy import deepcopy
import json

import requests
from urllib3.exceptions import InsecureRequestWarning
from requests.exceptions import Timeout, ConnectionError

from src.typings import *
from src.utils import *
from ..agent import AgentClient

old_merge_environment_settings = requests.Session.merge_environment_settings


@contextlib.contextmanager
def no_ssl_verification():
    opened_adapters = set()

    def merge_environment_settings(self, url, proxies, stream, verify, cert):
        # Verification happens only once per connection so we need to close
        # all the opened adapters once we're done. Otherwise, the effects of
        # verify=False persist beyond the end of this context manager.
        opened_adapters.add(self.get_adapter(url))

        settings = old_merge_environment_settings(self, url, proxies, stream, verify, cert)
        settings['verify'] = False

        return settings

    requests.Session.merge_environment_settings = merge_environment_settings

    try:
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', InsecureRequestWarning)
            yield
    finally:
        requests.Session.merge_environment_settings = old_merge_environment_settings

        for adapter in opened_adapters:
            try:
                adapter.close()
            except:
                pass


class Prompter:
    @staticmethod
    def get_prompter(prompter: Union[Dict[str, Any], None]):
        # check if prompter_name is a method and its variable
        if not prompter:
            return Prompter.default()
        assert isinstance(prompter, dict)
        prompter_name = prompter.get("name", None)
        prompter_args = prompter.get("args", {})
        if hasattr(Prompter, prompter_name) and callable(
            getattr(Prompter, prompter_name)
        ):
            return getattr(Prompter, prompter_name)(**prompter_args)
        return Prompter.default()

    @staticmethod
    def default():
        return Prompter.role_content_dict()

    @staticmethod
    def batched_role_content_dict(*args, **kwargs):
        base = Prompter.role_content_dict(*args, **kwargs)

        def batched(messages):
            result = base(messages)
            return {key: [result[key]] for key in result}

        return batched

    @staticmethod
    def role_content_dict(
        message_key: str = "messages",
        role_key: str = "role",
        content_key: str = "content",
        user_role: str = "user",
        agent_role: str = "agent",
    ):
        def prompter(messages: List[Dict[str, str]]):
            nonlocal message_key, role_key, content_key, user_role, agent_role
            role_dict = {
                "user": user_role,
                "agent": agent_role,
            }
            prompt = []
            for item in messages:
                prompt.append(
                    {role_key: role_dict[item["role"]], content_key: item["content"]}
                )
            return {message_key: prompt}

        return prompter

    @staticmethod
    def prompt_string(
        prefix: str = "",
        suffix: str = "AGENT:",
        user_format: str = "USER: {content}\n\n",
        agent_format: str = "AGENT: {content}\n\n",
        prompt_key: str = "prompt",
    ):
        def prompter(messages: List[Dict[str, str]]):
            nonlocal prefix, suffix, user_format, agent_format, prompt_key
            prompt = prefix
            for item in messages:
                if item["role"] == "user":
                    prompt += user_format.format(content=item["content"])
                else:
                    prompt += agent_format.format(content=item["content"])
            prompt += suffix
            print(prompt)
            return {prompt_key: prompt}

        return prompter

    @staticmethod
    def claude():
        return Prompter.prompt_string(
            prefix="",
            suffix="Assistant:",
            user_format="Human: {content}\n\n",
            agent_format="Assistant: {content}\n\n",
        )

    @staticmethod
    def palm():
        def prompter(messages):
            return {"instances": [
                Prompter.role_content_dict("messages", "author", "content", "user", "bot")(messages)
            ]}
        return prompter


def check_context_limit(content: str):
    content = content.lower()
    and_words = [
        ["prompt", "context", "tokens"],
        [
            "limit",
            "exceed",
            "max",
            "long",
            "much",
            "many",
            "reach",
            "over",
            "up",
            "beyond",
        ],
    ]
    rule = AndRule(
        [
            OrRule([ContainRule(word) for word in and_words[i]])
            for i in range(len(and_words))
        ]
    )
    return rule.check(content)


class HTTPAgent(AgentClient):
    def __init__(
        self,
        url,
        proxies=None,
        body=None,
        headers=None,
        return_format="{response}",
        prompter=None,
        **kwargs,
    ) -> None:
        super().__init__(**kwargs)
        self.url = url
        self.proxies = proxies or {}
        self.headers = headers or {}
        self.body = body or {}
        self.return_format = return_format
        self.prompter = Prompter.get_prompter(prompter)
        if not self.url:
            raise Exception("Please set 'url' parameter")

    def _handle_history(self, history: List[dict]) -> Dict[str, Any]:
        return self.prompter(history)

    def inference(self, history: List[dict]) -> str:
        for _ in range(3):
            try:
                body = self.body.copy()
                body.update(self._handle_history(history))
                with no_ssl_verification():
                    resp = requests.post(
                        self.url, json=body, headers=self.headers, proxies=self.proxies, timeout=120
                    )
                # print(resp.status_code, resp.text)
                if resp.status_code != 200:
                    # print(resp.text)
                    if check_context_limit(resp.text):
                        raise AgentContextLimitException(resp.text)
                    else:
                        raise Exception(
                            f"Invalid status code {resp.status_code}:\n\n{resp.text}"
                        )
            except AgentClientException as e:
                raise e
            except Exception as e:
                print("Warning: ", e)
                pass
            else:
                resp = resp.json()
                return self.return_format.format(response=resp)
            time.sleep(_ + 2)
        raise Exception("Failed.")


class LmdeployAgent:
    def __init__(
        self,
        model_name,
        model_url,
        **kwargs,
    ) -> None:
        from lagent.llms.lmdepoly_wrapper import LMDeployClient
        from lagent.llms.meta_template import INTERNLM2_META as META
        self.client = LMDeployClient(
            model_name=model_name,
            url=model_url,
            meta_template=META,
            **kwargs)
        self.model_name = model_name
        self.roles_cfg = dict(
            assistant=dict(
                begin='<|im_start|>assistant\n',
                end='<|im_end|>\n'
            ),
            user=dict(
                begin='<|im_start|>user\n',
                end='<|im_end|>\n'
            ),
            environment=dict(
                begin='<|im_start|>environment\n',
                end='<|im_end|>\n'
            )
        )

    def inference(self, history: List[dict]) -> str:
        for _ in range(3):
            try:
                new_history = []
                for item in deepcopy(history):
                    if item['role'] == 'agent':
                        item['role'] = 'assistant'
                        webshop_wording = 'Ok.'
                        kg_wording = 'I have understood your instruction, start please.'
                        alfworld_wording = 'OK. I will follow your instructions and try my best to solve the task.'
                        cg_wording = 'Okay, I will play the game with you according to the rules.'
                        if item['content'] in [webshop_wording, kg_wording, alfworld_wording, cg_wording]:
                            continue
                        else:
                            new_history.append(item)
                    elif item['role'] == 'user':
                        role = 'user'
                        user_content = item['content']
                        if not isinstance(user_content, str):
                            user_content = json.dumps(user_content, ensure_ascii=False)
                        if user_content.startswith('Observation:'):
                            user_content = user_content.split('Observation:')[1].strip()
                            # role = 'environment'
                        if new_history and new_history[-1]['role'] == 'user':
                            new_history[-1]['content'] += '\n' + user_content
                        else:
                            new_history.append(
                                dict(
                                    role=role,
                                    content=user_content
                                )
                            )
                prompt = ''
                for item in new_history:
                    role_cfg = self.roles_cfg[item['role']]
                    temp_str = role_cfg['begin'] + item['content'] + role_cfg['end']
                    prompt += temp_str
                prompt += self.roles_cfg['assistant']['begin']
                for model_state, res, _ in self.client.stream_chat(prompt):
                    if model_state.value < 0:
                        raise Exception(
                            f"Invalid status code {model_state}:\n\n{res}"
                        )
                # print('*'*20)
                # print(new_history)
                # print('-'*20)
                # print(prompt)
                # print('%'*20)
                # print(res)
                # print('*'*20)
                return res
            # if timeout or connection error, retry
            except Timeout:
                print("Timeout, retrying...")
            except ConnectionError:
                print("Connection error, retrying...")
            except Exception as e:
                exc_type, exc_value, exc_traceback_obj = sys.exc_info()
                traceback.print_tb(exc_traceback_obj)
            time.sleep(5)
        else:
            raise Exception("Timeout after 3 retries.")