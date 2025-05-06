require 'json'

class Library
  def initialize
    @books = []
    @users = []
    @loans = []
    carregar_dados
  end

  def adicionar_livro
    print "Título: "
    titulo = gets.chomp
    print "Autor: "
    autor = gets.chomp
    print "Ano de publicação: "
    ano = gets.chomp.to_i
    id = @books.size + 1
    @books << Book.new(id: id, titulo: titulo, autor: autor, ano_publicacao: ano)
    puts "Livro adicionado com sucesso!"
  end

  def registrar_usuario
    print "Nome: "
    nome = gets.chomp
    print "Email: "
    email = gets.chomp
    id = @users.size + 1
    @users << User.new(id: id, nome: nome, email: email)
    puts "Usuário registrado com sucesso!"
  end

  def listar_usuarios
    if @users.empty?
      puts "Nenhum usuário registrado!"
    else
      puts "\n===== LISTA DE USUÁRIOS ====="
      @users.each do |user|
        puts "ID: #{user.id} | Nome: #{user.name} | Email: #{user.email}"
      end
    end
  end

  def remover_usuario
    listar_usuarios
    print "Digite o ID do usuário que deseja remover: "
    id = gets.chomp.to_i
    user = @users.find { |u| u.id == id }
  
    if user
      @users.delete(user)
      puts "Usuário removido com sucesso."
    else
      puts "Usuário não encontrado."
    end
  end

  def listar_livros_disponiveis
    disp = @books.select(&:disponivel)
    if disp.empty?
      puts "Nenhum livro disponível."
    else
      disp.each { |b| puts "#{b.id} - #{b.titulo} (#{b.autor})" }
    end
  end

  def emprestar_livro
    listar_livros_disponiveis
    print "ID do livro para emprestar: "
    book_id = gets.chomp.to_i
    print "ID do usuário: "
    user_id = gets.chomp.to_i

    livro = @books.find { |b| b.id == book_id && b.disponivel }
    usuario = @users.find { |u| u.id == user_id }

    if livro && usuario
      livro.disponivel = false
      @loans << { book_id: livro.id, user_id: usuario.id }
      puts "Livro emprestado!"
    else
      puts "Livro ou usuário inválido."
    end
  end

  def devolver_livro
    print "ID do livro a devolver: "
    book_id = gets.chomp.to_i
    loan = @loans.find { |l| l[:book_id] == book_id }
    livro = @books.find { |b| b.id == book_id }

    if loan && livro
      livro.disponivel = true
      @loans.delete(loan)
      puts "Livro devolvido!"
    else
      puts "Empréstimo não encontrado."
    end
  end

  def salvar_dados
    data = {
      books: @books.map(&:to_h),
      users: @users.map(&:to_h),
      loans: @loans
    }
    File.write('data.json', JSON.pretty_generate(data))
    puts "Dados salvos!"
  end

  def carregar_dados
    return unless File.exist?('data.json')

    data = JSON.parse(File.read('data.json'), symbolize_names: true)
    @books = data[:books].map { |b| Book.new(**b) }
    @users = data[:users].map { |u| User.new(**u) }
    @loans = data[:loans]
  end

  def menu
    loop do
      puts "\n1. Adicionar livro"
      puts "2. Registrar usuário"
      puts "3. Emprestar livro"
      puts "4. Devolver livro"
      puts "5. Listar livros disponíveis"
      puts "6. Sair"
      print "Escolha: "
      opcao = gets.chomp.to_i

      case opcao
      when 1 then adicionar_livro
      when 2 then registrar_usuario
      when 3 then emprestar_livro
      when 4 then devolver_livro
      when 5 then listar_livros_disponiveis
      when 6
        salvar_dados
        break
      else
        puts "Opção inválida!"
      end
    end
  end
end
