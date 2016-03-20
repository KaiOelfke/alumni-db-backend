# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
  
  #only to produce fake data
  #require "faker"

  users = [{uid: '_kai@alumnieurope.org',
              provider: 'email',
              email: '_kai@alumnieurope.org',
              password: '12345678',
              first_name: 'Kai',
              last_name: 'Oelfke',
              country: 'DE',
              city: 'Berlin',
              date_of_birth: '17.04.1992',
              gender: 0,
              program_type: 0,
              institution: 'Luise-Henriette-Schule',
              year_of_participation: 2010,
              country_of_participation: 'DE',
              student_company_name: 'StudentsArt Berlin',
              university_name: 'Freie Universität Berlin',
              university_major: 'Informatik',
              founded_company_name: '',
              current_company_name: 'iOS Apps',
              current_job_position: 'Freelancer',
              interests: 'Mario Kart',
              short_bio: 'Bio muss noch ausgefüllt werden.',
              alumni_position: 'European Board',
              member_since: '01.06.2011',
              facebook_url: 'https://www.facebook.com/Kai.Oelfke',
              skype_id: 'kai.oelfke',
              twitter_url: '',
              linkedin_url: 'https://de.linkedin.com/pub/kai-oelfke/58/191/a74/en',
              mobile_phone: '+4917670261855',
              registered: true,
              completed_profile: true,
              is_super_user: true},
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
              is_super_user: true},
             {uid: 'can.goektas@gmail.com',
              provider: 'email',
              email: '_can.goektas@gmail.com',
              password: '00000000',
              first_name: 'Can',
              last_name: 'Göktas',
              country: 'DE',
              city: 'Berlin',
              date_of_birth: '12.10.1990',
              gender: 0,
              program_type: 0,
              institution: 'TBC',
              year_of_participation: 2010,
              country_of_participation: 'DE',
              student_company_name: 'TBC',
              university_name: 'FU Berlin',
              university_major: 'Informatik',
              founded_company_name: '',
              current_company_name: 'DAI Labor',
              current_job_position: 'Entwickler',
              interests: 'Fußball',
              short_bio: 'TBC',
              alumni_position: 'Volunteer',
              member_since: '01.10.2014',
              facebook_url: 'https://www.facebook.com/cgoektas',
              skype_id: 'cangoektas',
              twitter_url: '',
              linkedin_url: '',
              mobile_phone: '',
              registered: true,
              completed_profile: true,
              is_super_user: true}]

=begin
  
  for i in 0..10000
    em = Faker::Internet.email

    users.push({

                uid: em,
                provider: 'email',
                email: '_'+em,
                password: '00000000',
                first_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                country: 'DE',
                city: 'Berlin',
                date_of_birth: '12.10.1990',
                gender: 0,
                program_type: 0,
                institution: 'TBC',
                year_of_participation: 2010,
                country_of_participation: 'DE',
                student_company_name: 'TBC',
                university_name: 'FU Berlin',
                university_major: 'Informatik',
                founded_company_name: '',
                current_company_name: 'DAI Labor',
                current_job_position: 'Entwickler',
                interests: 'Fußball',
                short_bio: 'TBC',
                alumni_position: 'Volunteer',
                member_since: '01.10.2014',
                facebook_url: 'https://www.facebook.com/cgoektas',
                skype_id: 'cangoektas',
                twitter_url: '',
                linkedin_url: '',
                mobile_phone: '',
                registered: true,
                completed_profile: true,
                is_super_user: true



      })
  end  
=end



  plans = [{
        name: "default plan",
        price: 25,
        default: true
        }]

  users = User.create(users)

  plans = Subscriptions::Plan.create(plans)
