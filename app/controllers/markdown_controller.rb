class MarkdownController < ApplicationController
  def readme = rendered_markdown('README.md')
  def todo = rendered_markdown('TODO.md')

protected
  def rendered_markdown(path)
    @html = MarkdownRenderer.render(path)
    respond_to do |format|
      format.html { render 'markdown/show', content: @html, layout: !request.xhr? }
    end
  end
end
