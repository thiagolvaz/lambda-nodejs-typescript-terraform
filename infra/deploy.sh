function deploy {

  # Create a dist folder in the infra folder to store the build zip files
  mkdir dist

  # Move into the app folder
  cd ../app/ && \
  
  # Run the npm commands to transpile the TypeScript to JavaScript
  npm i && \
  npm run build && \
  npm prune --production &&\
  
  # Create a dist folder in the app folder and copy only the js files to dist.
  # AWS Lambda does not have a use for a package.json or typescript files on runtime.
  mkdir dist &&\
  cp -r ./src/*.js dist/ &&\
  cp -r ./node_modules dist/ &&\
  
  # Move into the dist folder
  cd dist

  # Remove all zip files from the dist folder
  find . -name "*.zip" -type f -delete && \

  # Zip everything in the dist folder and
  zip -r ../../infra/dist/lambda_function.zip . && \

  # Move back to the app folder and remove the dist folder
  cd .. && rm -rf dist &&\

  # Clean compiled js files
  tsc --build --clean && \

  # Move into the infra folder and run the terraform commands
  cd ../infra && \
  terraform plan -input=false -out=./tfplan && \
  terraform apply -input=false ./tfplan && \

  # Remove the dist folder
  rm -rf dist
}

deploy