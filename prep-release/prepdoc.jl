using BDF, Lexicon


Lexicon.save("../docs/API.md", BDF)
cd("../")
run(`mkdocs build`)
cd("prep-release")
