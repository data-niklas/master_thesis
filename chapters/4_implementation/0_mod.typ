#import "/utils.typ": *
= Implementation <implementation>
// Heavily using Transformers and Huggingface's libraries
// Background section showed that huggingface has all needed components, as we will see later

After having analyzed techniques and previous work based on the requirements, @design showed the need for an #acr("IBMS") and custom dataset. The #acr("IBMS") is used in the proposed approach to inject context into the prompt "during" generation, while the custom dataset can be used to obtain results and evaluate these.

In contrast, this chapter implements the proposed approach and dataset. The implementation of the proposed approach includes both the use of the #acr("IBMS") and further implementations for information filtering and logits manipulation. The section will use the components in @fig:lsp-aided-components and only mention if the behavior is part of context injection and thus #acr("IBMS").

#{
  include "1_lsp_aided_generation.typ"
  include "2_dataset_design.typ"
}

/* ~ General flow ~

  ~ Goals ~
  Talk about implementation details and tweaks / hacks

  ~ Non goals ~
  Show results / benchmarking
*/
