# Decisions

This document holds the decisions that govern Website. A plan must not go
against a decision. To change a decision, propose the change and get human
approval first.

| ID   | Decision                                                                                                                                                         | Rationale                                                                                                                                             |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| D-01 | The repository holds site content, and a published artifact that the organization serves at a stable address. It holds no application code, and no build recipe. | fuguweb(1) builds the site, and the shared workflow publishes it. `web/keys/` is the precedent: the site already serves artifacts that are not pages. |
| D-02 | The project list on the front page is manual.                                                                                                                    | A manual list stays deliberate, and the organization is small.                                                                                        |
