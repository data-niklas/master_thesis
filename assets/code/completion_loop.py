# llm_lsp/generator.py
async def _complete(self, code: str, repo_root: str, file_name: str) -> str:
        self.log_code(code, "START")
        (...) = self.initialize_generation_state(code, repo_root, file_name)

        prompt = prompt_states[0].format(code)
        input_ids = self.tokenizer(
            prompt, return_tensors="pt", add_special_tokens=False
        ).input_ids
        input_ids, _ = self.expand_input_ids(input_ids, config)<code_completion_expansion>
        while True:<code_completion_loop_while_start>
            decoded_text = self.resume_generation(input_ids, ...)
            interrupt = lsp_processor.interrupt
            if interrupt is None:
                prompt_state = prompt_states[0]
                return self.retrieve_final_code(prompt_state, decoded_text)<code_completion_loop_while_end>
            stopped_beam_index = self.index_of_beam_to_edit(interrupt.input_ids)
            prompt_state = prompt_states[stopped_beam_index]
            if max_interrupts is not None:
                if max_interrupts == 0:
                    return self.retrieve_final_code(prompt_state, decoded_text)
                max_interrupts = max_interrupts - 1
            code_util = code_utils[stopped_beam_index]
            edited_prompt = self.edit_generation_text_for_completion(<code_completion_prompt_edit_start>
                decoded_text, prompt_state, interrupt, code_util
            )
            input_ids = self.edit_input_ids(<code_completion_loop_edit_input_ids_start>
                interrupt, edited_prompt, stopped_beam_index
            )<code_completion_loop_edit_input_ids_end>
            self.log_interruption(input_ids, interrupt_count)

