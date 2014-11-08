# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#

   users = [{ username: 'Ahmed Issa', email: 'neuissa@gmail.com' },
            { username: 'Kai Oelfke', email: 'k.oelfke@me.com' },
            { username: 'Can Goektas', email: 'can.goektas@gmail.com'}]
   users = User.create(users)
#   Mayor.create(name: 'Emanuel', city: cities.first)
