"""One in-process SDK conversation inside the already isolated worker container."""
import json
from pathlib import Path


def run_to_completion(conversation, finished_status):
    conversation.run()
    # ERROR/STUCK may be returned without an exception by the pinned SDK.
    if conversation.state.execution_status != finished_status:
        raise RuntimeError('OpenHands did not finish successfully')


def main():
    from openhands.sdk import LLM, Agent, Conversation, Tool
    from openhands.sdk.conversation.state import ConversationExecutionStatus
    from openhands.tools.file_editor import FileEditorTool
    from openhands.tools.terminal import TerminalTool
    from pydantic import SecretStr

    policy = json.loads(Path('/policy/run.json').read_text())
    llm = LLM(model='openai/' + policy['model'], base_url='http://127.0.0.1:8123/v1',
              api_key=SecretStr('local'))
    # Terminal execution stays in networkless Docker, never on the host.
    agent = Agent(llm=llm, tools=[Tool(name=TerminalTool.name), Tool(name=FileEditorTool.name)])
    conversation = Conversation(agent=agent, workspace='/workspace')
    conversation.send_message(Path('/policy/prompt.txt').read_text(encoding='utf-8'))
    run_to_completion(conversation, ConversationExecutionStatus.FINISHED)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
