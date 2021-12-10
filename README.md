# 21241-f21
21241-f21 (CMU) Final Project on PageRank and HITS.

In the current technological era, the first thing most people think of when trying to find an answer to a question they might not know is to ```google it```. As such, the Google search engine's job is to return the most relevant information to the user after a search. Thus, in order to effectively conduct a search, it is essential that a search engine has a method to rank the importance of results (in this case webpages). Although this concept in theory is pretty simple, there are still a few defining parameters that aren't necessarily easy to rigorize when trying to tackle this issue, including those such as how do we actually assess the importance of a page? And how do we compare the importance of different pages (what makes a page more important than other pages)?

The answer to these questions for Stanford PhD students Sergey Brin and Larry Page was the PageRank algorithm they developed in 1996 (as part of a research project). Brin believed that web pages could be sorted based on something called ```link popularity```, the idea that a web page was more popular if it had more links to it. Thus, under this assumption, the internet can be visualized as a directed graph with web pages as the nodes and links between them as edges. The way that PageRank works is it calculates the ranking of a webpage based on the number of links coming to and from the graph as well as considering the possibility that the user goes to another page (```teleportation```) or stops browsing (```damping factor```). In this paper, we will be explaining and analyzing each of these factors in terms of how they make up the PageRank algorithm and the linear algebra necessary for the whole process.

Included in this repository is:
- PDF of our paper
- All of our code written in Julia (```pagerank.jl```)
- Our datasets
- Some of our results
