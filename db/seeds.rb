# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#


    users = [
             {uid: 'neuissa@gmail.com',
              provider: 'email',
              email: 'neuissa@gmail.com',
              password: '12345678',
              first_name: 'Ahmed',
              last_name: 'Issa',
              country: 'DE',
              city: 'Berlin',
              date_of_birth: '02.02.1993',
              gender: 0,
              program_type: 0,
              institution: 'TBC',
              year_of_participation: 2010,
              country_of_participation: 'DE',
              student_company_name: 'TBC',
              university_name: 'FU Berlin',
              university_major: 'Informatik',
              founded_company_name: '',
              current_company_name: 'innoscale',
              current_job_position: 'Entwickler',
              interests: 'Nein',
              short_bio: 'TBC',
              alumni_position: 'Volunteer',
              member_since: '01.10.2014',
              facebook_url: 'https://www.facebook.com/issaking',
              skype_id: 'barbarawy9',
              twitter_url: '',
              linkedin_url: '',
              mobile_phone: '',
              registered: true,
              completed_profile: true,
              is_super_user: true}]

  users = User.create(users)

