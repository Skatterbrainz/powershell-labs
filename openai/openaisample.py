import os
import openai

os.chdir('C:\\git\\powershell-labs\\openai')

openai.api_key = open('pykey.txt').read()

question = "List the 3 most populated US states with population, and abbreviation, output in json format"
aimodel = "text-davinci-003"

os.system('cls')
print('Submitting request to openai...')
response = openai.Completion.create(model=aimodel,prompt=question,temperature=0,max_tokens=1000)
print(response.choices[0].text)