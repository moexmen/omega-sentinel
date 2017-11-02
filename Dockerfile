FROM moexmen/node:8

ENV PATH node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH

ADD . .

RUN npm install

ENTRYPOINT ["node_modules/.bin/hubot"]

CMD ["--adapter", "slack"]
