module Zendesk
  class Client
    module Users
      # ## All GET requests for users
      #
      # ### V1
      #
      #    @zendesk.users                               - returns a list of users (limit 15)
      #    @zendesk.users.per_page(100)                 - returns a list of users (limit 15)
      #    @zendesk.users(123)                          - returns the user with id=123
      #    @zendesk.users("Bob")                        - returns users with name matching all or part of "Bob"
      #    @zendesk.users("Bob", :role => :end_user)    - returns users with name matching all or part of "Bob"
      #
      def users(*args)
        # passes the instance of the client into the collection
        # so that all the client configuration is visible for
        # making the actual HTTP requests
        UsersCollection.new(self, *args)
      end
      # cuz "users" are people: <3 your helpdesk.
      alias people users
    end

    class UsersCollection < Collection

      def initialize(client, *args)
        clear_cache
        @client = client
        @query  = args.last.is_a?(Hash) ? args.pop : {}

        case selection = args.shift
        when nil
          @query[:path] = "users"
        when Integer
          @query[:path] = "users/#{selection}"
        when String
          @query[:path]  = "users"
          @query[:query] = selection
        end
      end

      # ## Get currently authenticated user
      #
      #    @zendesk.users.current
      #
      def current
        @query[:path] += "/current"
        self
      end
      alias me current

      # ## Get a user's identities (email addresses, twitter handles, etc)
      #
      #    @zendesk.users(123).identities
      #
      # TODO: incredibly dumb
      def identities
        @query[:path] += "/user_identities"
        self
      end

      # ## Create a user
      #
      # ### V1
      #
      #    @zendesk.users.create({:name => "Mr. Miyagi"})
      #
      #    # optional block syntax
      #    @zendesk.users.create do |user|
      #      user[:name] = "Mr. Miyagi"
      #    end
      #
      def create(data={})
        yield data if block_given?
        do_post(@query.delete(:path), @query.merge(:user => data))
      end

      # ## Update a user
      #
      # ### V1
      #
      #    @zendesk.users(123).update({:email => "hongkong@phooey.com"})
      #
      #    # optional block syntax
      #    @zendesk.users(123).update do |user|
      #      user[:email] = "hongkong@phooey.com"
      #    end
      #
      def update(data={})
        yield data if block_given?
        do_put(@query.delete(:path), @query.merge(:user => data))
      end

      # ## Delete a user
      #
      # ### V1
      #
      #    @zendesk.users(123).delete
      #
      def delete(options={})
        do_delete(@query.delete(:path), options)
      end

    end
  end
end
