# llm_lsp/generation_utils/beam_tracking.py
class BeamIndexStoringSearchScores(BeamSearchScorer):
    def process(self, beam_indices, ...):
        self.beam_tracker.track_beam_indices(beam_indices)
        return super().process(...)

    def finalize(self, input_ids, beam_indices, ...):
        self.input_ids = input_ids
        self.beam_tracker.track_beam_indices(beam_indices)
        return super().finalize(...)

