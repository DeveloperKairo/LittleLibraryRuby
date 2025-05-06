class Book
  attr_accessor :id, :titulo, :autor, :ano_publicacao, :disponivel

  def initialize(id:, titulo:, autor:, ano_publicacao:, disponivel: true)
    @id = id
    @titulo = titulo
    @autor = autor
    @ano_publicacao = ano_publicacao
    @disponivel = disponivel
  end

  def to_h
    {
      id: @id,
      titulo: @titulo,
      autor: @autor,
      ano_publicacao: @ano_publicacao,
      disponivel: @disponivel
    }
  end
end
