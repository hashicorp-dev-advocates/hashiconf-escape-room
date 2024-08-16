FROM danlynn/ember-cli:5.10.0

EXPOSE 4200 7357 9222
CMD ["ember server"]

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY package.json .
COPY yarn.lock .

RUN yarn

# Copy all our app's directories
COPY . .