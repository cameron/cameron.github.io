# Docker and the Future of SaaS

*tl;dr: Docker will enable a new model of software delivery wherein the end user owns more of their data than a current cloud provider does. Users will be empowered to run their own storage/logic service, leaving a relatively stateless router or central configuration hub to the service provider.*

## For non-techies

Docker is a tool that automates a tedious part of software development, and it's going to change not only the way we build software, but also the kind of software we build.

#### Applications have many homes

As it turns out, developers actually have two jobs. Not only do they have to build applications, but they also have to manage their applications' various "homes". A web application, e.g., GMail, has a home that lets you and I interact with it through our web browser—this is called a **production server**, and its where the public-facing application lives. It also has a home designed to test it and ensure that the developers' latest work hasn't broken any of the existing features—this is called a **testing or staging server**, and it is not accessible via your web browser. An application has at least one more kind of home, a workshop where developers can do the real work of building the application, which is called a **development server**, and which is commonly the same as the laptop or desktop that a programmer work on.

Each one of these homes must outfitted appropriately, and outfitting homes is a tedious, complex, and error-prone process, as applications are pretty OCD and do not behave well if their home is not in order.

#### Docker builds and furnishes homes

Docker takes a short set of instructions from a developer and thus the responsibility for building and furnishing a home (again, in actuality, a server.)

## Why is SaaS SaaS?

As developers discovered the power of JavaScript, and browsers themselves evolved to support more application-like behavior, the software industry abandoned the expensive and slow process of distributing software on CD-ROMs in favor of online distribution.

From the user's perspective, SaaS has some undesirable properties:

- the provider is more likely to own your data, making it difficult to change providers
- service interruptions are made likely by the size and complexity of the system, and are totally outside the user's control




