# llm_lsp/interrupts/__init__.py
class InterruptType(ABC):
    @abstractmethod
    def type_name(self) -> str:
        pass

    @abstractmethod
    def create_comment(self, context: Any, code_util: CodeUtil) -> Optional[Comment]:
        pass

