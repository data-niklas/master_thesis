class Test(TestCase):
    def test_output_correctness(self):
        app = App()
        out = create_textual_text_area_with_indent()
        assert isinstance(out, TextArea)
        assert hasattr(out, "tab_behavior")
        assert out.tab_behavior == "indent"

    def test_approach_correctness(self):
        app = App()
        TextArea = MagicMock(TextArea)
        globals()["TextArea"] = TextArea
        out = create_textual_text_area_with_indent()
        assert TextArea.call_count == 1
        kwargs = TextArea.call_args.kwargs
        assert "tab_behavior" in kwargs
        assert "tab_behaviour" not in kwargs
        assert kwargs["tab_behavior"] == "indent"
