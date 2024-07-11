#import "/utils.typ": *
== Interrupt-based meta-strategy
// While the implementation directly focuses on the final approach, this section will focus on the implementation details needed to enable injecting contexts into the prompt

#todo()[Rename classes in LLM LSP]
=== Generator
// implemented using a class, wrap

// connection to LSP, but will be detailed in the next section

// add special tokens and resize embeddings
// add pad token, as not every model has padding

// contextmanager for device placement
// from huggingface pipeline, but needed

==== Completion
1. init objects for generation for each beam (monitor is stateless so only 1 instance)
2. create lsp for each language
3. init config and add fixes
4. expand input ids (normally in generate function)
5. loop and use custom generation
  - if no interrupt -> get completion, done
  - else
    - edit prompt
    - insert into beams and edit input ids => add padding to max length of all to left side, then remove as much padding as possible on left (1. equalizes padding, 2. minimizes it)
    - clear interrupt
    - adjust config parameters

==== Resumption
- same arguments as generate

- reordering of static analysis requires deepcopy, as several objects have the same ancestor, thus branching off (copies)

=== BeamTracker
- Custom BeamSearchScores to enable beam search + logits processor order tracking and beam retrieval:
- saves input_ids before returning from the generate function (finalizing the beams)
- calls the tracker at each step

- BeamTracker
- List of beam selections
- iterates through the list, reproducing the beam selection process and storing the original ancestor beam index
- provides to rearrange list of items in the order of the beam search

- "only for beam search"

=== Monitor
logits guider
- self.interrupt = Interrupt object
-

=== PromptEditor
// fixing prompt back and forth
