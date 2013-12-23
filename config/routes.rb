Codelife::Application.routes.draw do
  get '/repo/:tag', to: 'repos#show', as: 'repo'
end
