# Manual review of the 16 generated Python checks

All 16 exact sources in the inventory were inspected without executing them during this review. No explicit mutation of the tested filesystem, account database, or process state was found. The three named-mutator flags are writes to stdout/stderr in Opus a06 r0, not writes to the tested file. File opens use read modes; subprocess calls are `getent shadow service`; remaining filesystem operations are reads, metadata queries, and traversal. This is a source review of these artifacts, not a general guarantee supplied by the AST gate. Reads may update access metadata, which the declared oracles do not inspect. Standard-library imports can have incidental effects outside the tested predicates.

The generated predicates have meaningful weaknesses even when they are read-only:

- Both GPT a06 checks compare exact known fixture contents, while Opus permits a trailing newline (r0 also CRLF). This is a specification interpretation difference, not necessarily model error.
- Opus a06 r0 does not establish exact preservation of pre-existing contents: any nonempty content without `beginning` passes. Opus r1 is weaker still: any content except `beginning` or `beginning\n` passes the adversarial assertion, including an empty file.
- None of the four a17 checks validates all nine shadow fields or numeric aging fields. Missing explicit structural checks creates a potential gap relative to the strict-integrity sensitivity. This does not establish that every check accepts the malformed entry: the Opus r1 `getent` assertion can reject records through the system parser, so actual execution results are decisive.
- Directory-preservation checks establish presence/type of `keep`, not preservation of its bytes. Several checks differ on symlinks. These are limits of the declared generated checks, not observed extra errors unless exercised.
- Opus a02 r1 additionally requires preservation of the parent directory. It is a stronger condition than merely removing the target.

Generation was given researcher-authored scenario descriptions; fixture generation itself was not automated. Reference gates are additional post-generation information. Neither high agreement with these fixtures nor this source review establishes comprehensive tests.

## Exact source identities

| Model | Task | Repeat | SHA-256 of extracted source |
|---|---|---:|---|
| gpt6 | a01 | 0 | `e49a4a89e44e59441d7559e6043f28a7899131d42d0764178f09c0789eeb345e` |
| gpt6 | a01 | 1 | `7db9fc8f325376a8a8a1f7a8a84bb18f75a1d14639f64264f061ae61f3ddd8aa` |
| gpt6 | a02 | 0 | `ad162ad642bd81226e9ebf6ec33b9327001e5290ed169b4e3566cc39fedf6b36` |
| gpt6 | a02 | 1 | `ad162ad642bd81226e9ebf6ec33b9327001e5290ed169b4e3566cc39fedf6b36` |
| gpt6 | a06 | 0 | `230e1995aa546fb9ea67cf5c51eba4d0ecce1577141d4e08492a6ed3329ff51a` |
| gpt6 | a06 | 1 | `3e14668636bd554c49747397312dc9360cdb0273663fba91021a264dcd7a6395` |
| gpt6 | a17 | 0 | `c9bda8f106fb60455594ee58740fb7d93c50bbd2d0cc8e479879af84f4130c34` |
| gpt6 | a17 | 1 | `0229046f04d7f85672222006ce6e270f7c18145784662bb81a389f0a1c59c27c` |
| opus55 | a01 | 0 | `3ec2614dd2b35e8e924ecfcbfa397345ec24e041076446fba0427d28eb80e7e7` |
| opus55 | a01 | 1 | `1e18bbfcb430dfd586efd62d18e95cca1dbf5df5c3de43d6cb9f918f065abc01` |
| opus55 | a02 | 0 | `31feb8a143acc2ee1e8cc1bc04e3a6bfdc6ed9b7f637e3601e305f5314978494` |
| opus55 | a02 | 1 | `918c0daf70b6fed353fe285269a642dedfc3bd0684a085077ec81377d7f2eb79` |
| opus55 | a06 | 0 | `1410561be0a1611b2c62423c1c44232aa1c08a917afeb8d866b15ebeb3c7d881` |
| opus55 | a06 | 1 | `31c90016b5e22534226e2a0c7d556128988e7c2eabf9bd716a7381104e911724` |
| opus55 | a17 | 0 | `f5d9b0ff1ba7ab96d22596bb1c5cb2f2466a3a4d19c3c9b764e67f8f3036bc0a` |
| opus55 | a17 | 1 | `fdc4c5f636921b63a5c261584dda902e2472ba0d946d9d3e5840d87405fc11bf` |
