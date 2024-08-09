def rearrange_according_to_beams(self, items):
    indices = self.get_final_beam_indices()
    if indices is None:
        indices = list(range(len(items)))
    return [items[indices[i]] for i in range(len(items))]

