# MindfullNest

### What?
MindfullNest is a webapp that allows hosting mindfullness classes. For example one may want to host a `Meditation for beginners` class. They can easily set it up and get others to join (and, in future, pay for) class online.

### Why?
* We feel there's a lack of solution like this focused on mindfullness
* In our opinion mindfullness is an important part of mental wellbeing, which, globally, is quite low
* Due to COVID situation many people are left without offline mindfullness classes, MindfullNest could help them
* We wanted to learn some Phoenix LiveView and make webapp with minimum JS possible :wink:

### To run app locally

* Install deps with `mix deps.get`
* Use `mix ecto.setup` for database creation, migration and seeding
* Install frontend deps by running `npm install --prefix assets`
* Start app with `mix phx.server`
* You can register (no real mail needed :smile:) or use existing users `email: meditation@guru password: MeditationIsFun` and `email: yoga@instructor password: YogaIsForEveryone`

**OR**

* Visit [MindfullNest on Heroku](https://fathomless-ridge-43338.herokuapp.com/) to see deployed app (there may be problem with video connection, more info below)


### What's next/what we didn't have time to do?

We will definetely continue working on this app, here are some things that we didn't manage to make or decided not to make during SpawnFest.

* STUN server to handle all connection cases. As for now the most reliable way is to connect locally from few browsers/windows. Code itself is quite trivial, but setting up Heroku is something else, sadly. This is why deployed app can have problems :(
* We're thinking of separating Organizers and Atendees somehow.
* Payment system - we believe that people who host those classes should be paid. Apart from obvious reasons - in COVID era this could help many trainers that were left without their offline classes.
* And few more ideas to make this into something more mature

### Demo video
![video](mindfull.mov)
