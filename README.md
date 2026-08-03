### Generate the resumes

Build every resume variant:

```sh
./build-resumes.sh
```

Build one variant by passing the suffix from its LaTeX filename:

```sh
./build-resumes.sh phd
./build-resumes.sh tech
```

The script discovers files named `latex/kiron_sukesan_resume_<suffix>.tex` and
writes each PDF to
`resumepdfs/<current-year>/<suffix>/kiron_sukesan_resume.pdf`.
