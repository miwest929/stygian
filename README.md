# Stygian #

Inspiration for the name: http://clash-of-the-titans.wikia.com/wiki/Stygian_Witches

## Overview ##
Stygian aspires to be an extremely powerful GitHub analyzer/visualizer. Using the GitHub API it can download all commits for a specified repository and puts each commit onto a shared message bus (eg: Apache Kafka). Consumers of this message log can consume each commit and perform some specific computation on it. UI is available to visualize how your codebase evolves through time (one of the consumers provides data for this). UI is also able to interact with the other consumers via exposed REST APIs to provide more context and information on the visualizations displayed.
