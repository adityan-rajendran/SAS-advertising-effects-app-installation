# Project: Analyzing the effectiveness of Ads through app installation
The data for this project comes from the mobile advertising space. In order to encourage consumers to install its app (e.g. a game), an app developer advertises its app on other apps (e.g., other games) through a mobile advertising platform. Consumers viewing these ads on these other apps can click on the ad to install the app from the developer.The advertising app developer is refferred to as as the advertiser.

The dataset for this project contains data about ads from one particular advertiser through multiple publishers. Each observation corresponds to one ad shown to a consumer on a particular publisher app. The observation contains information about the publisher id, consumer’s device characteristics, and whether the advertiser’s app was installed or not. This dataset is used to perform regression analysis and answer the question: will the consumer install the app or not ? (Is the ad effective or not ?)
The analysis is performed using SAS.

In addition to answering the stated question, the scenario also incorporates the situation of **Rare-event modelling**. A multitude of approaches are used to tackle this problem. In this analysis, penalized MLE will be primarily used to address rare-event modelling.
Also, the analysis will evolve contrasting the Logistic Regression model and the Linear proabability model.
