Metplus
==========================
MetPlus is a non-profit that aim to help the people of Detroit, and hopefully Michigan, to find a job that suits them. The vision of the client is to create one application(PETS) that would allow the users to find the a job and for companies to find employers.

==========================
Public Employment Tracking System – P.E.T.S.

<a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Overview">Project Overview</a><br>
The PETS system is a web platform where the Job Seekers and the Companies can find each other. The platform will try to match all the skills of the Job Seekers and the skills needed by the Companies creating a pool of possible Jobs or Candidates...<a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Overview">Read more</a>

<a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Setup">Project Setup</a><br>
Find instructions for getting started <a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Setup">here</a>. (Note: assumes you already have a working Ruby on Rails development environment)

<a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Workflow">Project Workflow</a><br>
Learn about our project workflow process <a href="https://github.com/AgileVentures/MetPlus_PETS/wiki/Project-Workflow">here</a>.

See the whole wiki: <a href="https://github.com/AgileVentures/MetPlus_PETS/wiki">https://github.com/AgileVentures/MetPlus_PETS/wiki</a>

==========================
 - Semaphore [![Build Status](https://semaphoreci.com/api/v1/joaopapereira/metplus_pets-2/branches/master/badge.svg)](https://semaphoreci.com/joaopapereira/metplus_pets-2) / [![Build Status](https://semaphoreci.com/api/v1/joaopapereira/metplus_pets-2/branches/development/badge.svg)](https://semaphoreci.com/joaopapereira/metplus_pets-2)
 - Code Climate [![Code Climate](https://codeclimate.com/github/AgileVentures/MetPlus_PETS/badges/gpa.svg)](https://codeclimate.com/github/AgileVentures/MetPlus_PETS)
 - Test Coverage [![Test Coverage](https://codeclimate.com/github/AgileVentures/MetPlus_PETS/badges/coverage.svg)](https://codeclimate.com/github/AgileVentures/MetPlus_PETS/coverage)
 - Waffle [![Stories in Progress](https://badge.waffle.io/AgileVentures/MetPlus_tracker.png?label=in%20progress&title=In%20Progress)](http://waffle.io/AgileVentures/MetPlus_tracker)

 
# Deployment with Dokku

1. Create the Postgres Database
`ssh dokku@agileventures.azure postgres:create metplus-pets-production`

1. Create the Application
`ssh dokku@agileventures.azure apps:create metplus-pets-production`

1. Link Mongo Database with Application
`ssh dokku@agileventures.azure postgres:link metplus-pets-production metplus-pets-production`

1. Configure application
`ssh dokku@agileventures.azure config:set `

1. Create remote to push application to
`git remote add production dokku@agileventures.azure:metplus-pets-production`

1. Deploy to production
`git push production master`
