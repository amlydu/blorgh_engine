# Blorgh :notebook:

This project rocks and uses MIT-LICENSE.

I am mostly using this project as a means of learning how to create a Rails engine; the README will mostly be for *me* to *read* later on as a reference tool. :thumbsup:

This is based off the tutorial here: [Getting Started With Engines](http://guides.rubyonrails.org/engines.html)

## How To Make an Engine

### Generating An Engine

```
$ rails plugin new blorgh --mountable
```
- The `--mountable` option tells the generator that you want to create a "mountable" and namespace-isolated engine.
  - This generator will provide the same skeleton structure as would the `--full` option and more... :sparkles:
  - Additionally, the `--mountable` option tells the generator to *mount the engine inside the dummy testing application* located at `test/dummy` by adding the following to the dummy application's routes file at `test/dummy/config/routes.rb`:
    - `mount Blorgh::Engine => "/blorgh"`

### Inside an Engine

- Within `lib/blorgh/engine.rb` is the base class for the engine:
```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```
- By inheriting from the `Rails::Engine` class, this gem notifies Rails that there's an engine at the specified path, and will correctly mount the engine inside the application, performing tasks such as adding the app directory of the engine to the load path for models, mailers, controllers and views.
  - The `isolate_namespace` method here deserves special notice. This call isolates the controllers, models, routes and other things into their own namespace, away from similar components inside the application.
  - **Without this, there is a possibility that the engine's components could "leak" into the application, causing unwanted disruption, or that important engine components could be overridden by similarly named things within the application.**
    - One of the examples of such conflicts is helpers. Without calling `isolate_namespace`, the engine's helpers would be included in an application's controllers.
    - Hey smart guy, yah you - **It is highly recommended that the `isolate_namespace` line be left within the Engine class definition**. Without it, classes generated in an engine may conflict with an application.
  - What this isolation of the namespace means:
    - A model generated by a call to `bin/rails g model`, such as `bin/rails g model article`, won't be called `Article`, but instead be namespaced and called `Blorgh::Article`.
    - The table for the model is namespaced, becoming `blorgh_articles`, rather than simply `articles`.
    - Similar to the model namespacing, a controller called `ArticlesController` becomes `Blorgh::ArticlesController` and the views for that controller will not be at `app/views/articles`, but `app/views/blorgh/articles` instead.
    - Mailers are namespaced as well.
    - Routes will also be isolated within the engine. This is one of the most important parts about namespacing! :exclamation:
- bin Directory
  - This enables you to use the rails sub-commands and generators just like you would within an application.
    - You will be able to generate new controllers and models for this engine very easily by running commands like this:
    ```
    $ bin/rails g model
    ```
    - Anything generated with these commands inside of an engine that has `isolate_namespace` in the Engine class will be namespaced.

### Adding Functionality

- Scaffold a `Article` with `title` and `text` attributes.
  - **Note here**: the migration is called `create_blorgh_articles` rather than the usual `create_articles`.
    - This is because of the `isolate_namespace` method called in the `Blorgh::Engine` class's definition.
    - The model here is also namespaced, being placed at `app/models/blorgh/article.rb` rather than `app/models/article.rb` due to the `isolate_namespace` call within the Engine class.
  - Routes are drawn upon the `Blorgh::Engine` object rather than the `YourApp::Application` class.
    - This is so that the engine routes are confined to the engine itself and can be mounted at a specific point.
    - It also isolates the engine's routes from those routes that are within the application.
- `rails server` can be run from `test/dummy`
  - You can check out the functionality at `http://localhost:3000/blorgh/articles`
- You can also play around in the `rails console`!
  - Remember: the Article model is namespaced, so to reference it you must call it as `Blorgh::Article`.
    ```ruby
    >> Blorgh::Article.find(1)
    => #<Blorgh::Article id: 1 ...>
    ```
- Setting the root of the Engine:
  - One final thing is that the `articles` resource for this engine should be the root of the engine.
  - Just insert this line into the 1config/routes.rb1 file inside the engine: `root to: "articles#index"`
  - Now instead of having to visit `http://localhost:3000/blorgh/articles`, you only need to go to `http://localhost:3000/blorgh` now.
- Create a `Comment` model with a reference to an Article (`article_id:integer`)
  - Remember: this doesn't come along with the associated views or partials - so to render the comment text, remember to create a new file at `app/views/blorgh/comments/_comment.html.erb` and put whatever you want to render from the comments inside of it.
    - Example of what to put in view: `<%= comment_counter + 1 %>. <%= comment.text %>`
    - The `comment_counter` local variable is given to us by the `<%= render @article.comments %>` call, which will define it automatically and increment the counter as it iterates through each comment.
      - It's used in this example to display a small number next to each comment when it's created.
- NOTE: for Rails 4.1 and above -- apparently using `link_to` with `:delete` will perform an `HTTP GET` request
  - Had to use `button_to` to get `delete` working properly
  - Stackoverflow Answer: [Answer surrounding link_to and button_to delete method mystery for Rails 4.1 and above](http://stackoverflow.com/questions/18154916/rails-4-link-to-destroy-not-working-in-getting-started-tutorial)
    - Mention requiring certain JS gems in `application.js`
    - :question: Is this really JS related?

