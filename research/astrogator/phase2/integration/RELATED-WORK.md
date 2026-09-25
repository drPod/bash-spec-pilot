# Positioning the contribution honestly

The defensible contribution is an Astrogator-specific empirical and implementation
result, not the invention of specification validation or mutation-based repair.
Sources below were retrieved on 2026-09-25; this is a targeted positioning review,
not an exhaustive literature survey.

* **Astrogator itself** explicitly introduces a high-level formal query to mediate
  natural-language intent and code verification. Its design includes additional
  assumptions/actions requiring review. We must evaluate that interface, including
  residuals, rather than equate a base-verifier zero exit code with fully discharged
  correctness. [Councilman et al., 2025](https://arxiv.org/abs/2507.13290).
* **nl2spec** uses an interactive translation workflow with links between natural
  language and formal subformulas. Therefore, showing requirements alongside their
  generated formal fragments is established work, not a novel contribution here.
  [Cosler et al., 2023](https://arxiv.org/abs/2303.04864).
* **SpecGen** combines model-generated specifications, verifier feedback, and
  mutation-based refinement for program specifications. Verifiability and faithful
  user intent are distinct targets; our work must state which one each metric
  measures. [Ma et al.](https://arxiv.org/abs/2401.08807).
* **VeriSpecGen** directly overlaps the broad proposed approach: it decomposes
  requirements, generates targeted validation tests, and repairs specifications
  using requirement-level attribution. Its evaluation uses Lean specifications.
  We cannot claim the general idea of requirement-targeted specification tests or
  localized repair. [Ye et al., 2026](https://arxiv.org/html/2604.10392v1).

What this artifact can establish is narrower and concrete: permission-translation
behavior in Astrogator's actual implementation; executable counterexamples to
benchmark oracles; the distinction between query omissions, model limitations,
environment metadata, and unresolved residuals; and paired comparisons with
fresh stronger-model predictions on the supplied Ansible corpus. Generalization
beyond these tasks, novelty relative to all configuration-management verification
work, and the paper's final framing still require author review.

Ansible accepts both quoted octal modes and symbolic mode expressions, and uses
existing permissions when appropriate. The exact partial-symbolic update behavior
in our bug panel is established by recorded executions in the pinned Ansible 2.19.11
image, rather than inferred from a web example. [Official file-module documentation](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/file_module.html).
