R code examples to teach basic Web scraping with [`rvest`](https://cran.r-project.org/package=rvest) and related packages.

Used at a [two-day workshop][a] in November 2018: refer to the [introductory slides][b], in French, for details.

[a]: https://sygefor.reseau-urfist.fr/#/training/7432/8123/?from=true
[b]: https://frama.link/urfist-2018-slides

> Please report any __bugs or errors__ in the [issues](/briatte/urfist2018) of this repository, or [email me](mailto:f.briatte@gmail.com).

# DEMOS

1. `lagasafn` · legal cross-references in [Icelandic law](http://www.althingi.is/lagasafn/zip-skra-af-lagasafni/)
2. `jorf` · XML field extraction from the [French _Official Journal_](https://echanges.dila.gouv.fr/OPENDATA/JORFSIMPLE/)
3. `cop21` · word extraction from the [UNCC Paris Accord](https://unfccc.int/resource/docs/2015/cop21/eng/l09r01.pdf)
4. `qosd` · keyword co-occurrence in [French parliamentary questions](http://questions.assemblee-nationale.fr/)

Projects mentioned but not included in the repository:

- [`marsad`](https://github.com/briatte/marsad) · voting behaviour in the [Tunisian parliament](https://majles.marsad.tn/fr/assemblee)
- [`parlnet`](https://github.com/briatte/parlnet) · bill cosponsorship in European parliaments
- [`parlviz`](https://github.com/briatte/parlviz) · interactive visualizations of the above

Slides shown but not included in the repository (available on request):

- "Large-scale legislative data collection from online sources" (2016)
- "_Web scraping_ et APIs avec R" (2017)

# HOWTO

1. Run the [`dependencies.r`](dependencies.r) script to install all required packages.
2. Run each code folder separately. Each has its own `.Rproj` file.

# THANKS

- Sabrina Granger and Isabelle Scarpat-Bouvet for excellent logistics.
- Thomas J. Leeper for his [`word_count` function](https://gist.github.com/leeper/0d0c1ee2c671e03db21bbc45acf6b351), used in the `cop21` example.
- Emiliano Grossman for inspiring the `qosd` example.
