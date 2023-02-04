FROM ruby:3.2.0-bullseye

EXPOSE 3000

WORKDIR /usr/src/app
COPY . .

RUN bundle install
RUN chmod +x /usr/src/app/sbin/web
RUN chmod +x /usr/src/app/sbin/sidekiq

CMD [ "/usr/src/app/sbin/web" ]
