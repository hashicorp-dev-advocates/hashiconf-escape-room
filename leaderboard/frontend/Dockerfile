FROM danlynn/ember-cli:5.9.0 AS build

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY package.json .
COPY yarn.lock .

RUN yarn

# Copy all our app's directories
COPY . .

ENV LEADERBOARD_API http://api:9090

RUN ember build --environment=production

FROM nginx:1.27
COPY --from=build /app/dist /usr/share/nginx/html