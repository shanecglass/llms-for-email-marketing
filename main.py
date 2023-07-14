import secrets
import vertexai

from crypt import methods
from flask import Flask, render_template, redirect, url_for
from flask_bootstrap import Bootstrap5
from flask_wtf import FlaskForm, CSRFProtect
from modules import get_text_embeddings, get_response, publish_pubsub
from random import choices
from secrets import choice
from vertexai.preview.language_models import TextGenerationModel, TextEmbeddingModel
from wsgiref import validate
from wtforms import SubmitField, TextAreaField
from wtforms.validators import DataRequired

app = Flask (__name__, template_folder='./templates')
foo = secrets.token_urlsafe(16)
app.secret_key = foo
bootstrap = Bootstrap5(app)
csrf = CSRFProtect(app)

temperature = 0.9
token_limit = 500
top_p = 0.9
top_k = 40

class initialInputs(FlaskForm):
  prompt_purpose = TextAreaField('Describe the reason for the email. For example: Offer 15% off a purchase greater than $100 for customers who haven\'t purchased anything in the last 60 days',validators = [DataRequired()])
  prompt_tone = TextAreaField('Describe the tone you want your email content to have. For example: An edgy sporting goods company pretending to be a worried parent. Refer to the customer as \"sport\" and \"champ\"',validators = [DataRequired()])
  prompt_notes = TextAreaField('What other factors should be considered in this email, such as included discount codes? Example: Include the discount code \"MISSYOU15\", which is good for 15% off any purchase of $100 or more for the next month',validators = [DataRequired()])
  submit = SubmitField('Submit')

@app.route('/', methods=['GET', 'POST'])
def index():
  form = initialInputs()
  message = ""
  if form.validate_on_submit():
      prompt_tone = form.prompt_tone.data.replace('"', '\"').replace("'", "\'")
      prompt_purpose = form.prompt_purpose.data.replace('"', '\"').replace("'", "\'")
      prompt_notes = form.prompt_notes.data.replace('"', '\"').replace("'", "\'")
      input_prompt = f"""
        Write the body of a marketing email from Cymbal Retail that will {prompt_purpose}.
        The subject of the email should start with \'Subject:\' and the body of the email should start with \'Body:\'.
        Write it in the tone of {prompt_tone}.
        Make sure to incude {prompt_notes}
        """
      prompt_embed = get_text_embeddings(input_prompt)
      publish_pubsub(input_prompt, prompt_embed)
      output = get_response(input_prompt)
      response_embed = get_text_embeddings(output.text)
      publish_pubsub(output._prediction_response, response_embed)
      output_text = output.text
      return redirect( url_for('/review.html'), form=form, response=output_text)
  else:
      message = "Invalid inputs. Try again"
  return render_template('index.html', form=form, message=message)

@app.route('/review')
def output(response):
  if response is not None:
    return render_template('review.html', response=response)
  else:
    return render_template('500.html'), 500

# 2 routes to handle common errors
@app.errorhandler(404)
def page_not_found(e):
  return render_template('404.html'), 404

@app.errorhandler(500)
def internal_server_error(e):
  return render_template('500.html'), 500

# keep this as is
if __name__ == '__main__':
  app.run(debug=True)
