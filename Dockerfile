FROM ruby:2.4
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /MetPlus_PETS
WORKDIR /MetPlus_PETS
COPY Gemfile /MetPlus_PETS/Gemfile
COPY Gemfile.lock /MetPlus_PETS/Gemfile.lock
RUN bundle install --without production

# Install Chrome for Selenium
RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /chrome.deb
RUN dpkg -i /chrome.deb || apt-get install -yf
RUN rm /chrome.deb

# Install chromedriver for Selenium
RUN curl https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip -o /usr/local/bin/chromedriver
RUN chmod +x /usr/local/bin/chromedriver


COPY . /MetPlus_PETS
