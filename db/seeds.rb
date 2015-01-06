# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#


  statuses = [ {kind: 0}, {kind: 1}, {kind: 2}]

  statuses = Status.create(statuses)

  users = [ { first_name: 'Ahmed', last_name: 'Issa', email: 'neuissa@gmail.com', password: '12345678'},
            { first_name: 'Kai', last_name: 'Oelfke', email: 'k.oelfke@me.com', password: '12345678'},
            { first_name: 'Can', last_name: 'Goektas', email: 'can.goektas@gmail.com', password: '12345678'}]
  users = User.create(users)

