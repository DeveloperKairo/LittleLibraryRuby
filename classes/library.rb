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

  def remover_livro
    listar_livros
    print "Digite o ID do livro que deseja remover: "
    id = gets.chomp.to_i
    book = @books.find { |b| b.id == id }
  
    if book
      @books.delete(book)
      puts "Livro removido com sucesso."
    else
      puts "Livro não encontrado."
    end
  end

  def buscar_livro_por_nome
    livro = @books.find {|b| b.title.downcase.include?(nome.downcase)}
    if livro
      puts "Livro encontrado: ID: #{livro.id}, Título: #{livro.title}"
      return livro.id
    else
      puts "Livro não encontrado."
      nil
    end
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

  def buscar_usuario_por_nome(nome)
    usuario = @users.find {|u| u.name.downcase.include?(nome.downcase)}
    if usuario
      puts "Usuário encontrado: ID: #{usuario.id}, Nome: #{usuario.name}"
      return usuario.id
    else
      puts "Usuário não encontrado."
      nil
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

  def listar_emprestimos
    if @loans.empty?
      puts "Nenhum empréstimo ativo no momento."
      return
    end
  
    puts "\n===== EMPRÉSTIMOS ATIVOS ====="
    @loans.each do |loan|
      livro = @books.find { |b| b.id == loan[:book_id] }
      usuario = @users.find { |u| u.id == loan[:user_id] }
  
      if livro && usuario
        puts "Livro: #{livro.titulo} (ID: #{livro.id})"
        puts "Emprestado para: #{usuario.name} (ID: #{usuario.id})"
        puts "---------------------------------"
      else
        puts "Empréstimo inválido ou dados corrompidos (Livro ID: #{loan[:book_id]}, Usuário ID: #{loan[:user_id]})"
      end
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

  def menu_principal
    loop do
      puts "\n===== MENU PRINCIPAL ====="
      puts "1. Usuários"
      puts "2. Livros"
      puts "3. Empréstimos"
      puts "4. Sair"
      print "Escolha uma opção: "
      opcao = gets.chomp
  
      case opcao
      when "1"
        menu_usuarios
      when "2"
        menu_livros
      when "3"
        menu_emprestimos
      when "4"
        salvar_dados
        puts "Saindo do sistema. Até logo!"
        break
      else
        puts "Opção inválida. Tente novamente."
      end
    end
  end

  def menu_usuarios
    loop do
      puts "\n===== MENU USUÁRIOS ====="
      puts "1. Registrar Usuário"
      puts "2. Listar Usuários"
      puts "3. Remover Usuário"
      puts "4. Voltar ao Menu Principal"
      print "Escolha uma opção: "
      opcao = gets.chomp
  
      case opcao
      when "1"
        registrar_usuario
      when "2"
        listar_usuarios
      when "3"
        remover_usuario
      when "4"
        break
      else
        puts "Opção inválida. Tente novamente."
      end
    end
  end

  def menu_livros
    loop do
      puts "\n===== MENU LIVROS ====="
      puts "1. Registrar Livro"
      puts "2. Listar Livros"
      puts "3. Remover Livro"
      puts "4. Voltar ao Menu Principal"
      print "Escolha uma opção: "
      opcao = gets.chomp
  
      case opcao
      when "1"
        registrar_livro
      when "2"
        listar_livros
      when "3"
        remover_livro
      when "4"
        break
      else
        puts "Opção inválida. Tente novamente."
      end
    end
  end

  def menu_emprestimos
    loop do
      puts "\n===== MENU EMPRÉSTIMOS ====="
      puts "1. Emprestar Livro"
      puts "2. Devolver Livro"
      puts "3. Listar Empréstimos"
      puts "4. Voltar ao Menu Principal"
      print "Escolha uma opção: "
      opcao = gets.chomp
  
      case opcao
      when "1"
        emprestar_livro
      when "2"
        devolver_livro
      when "3"
        listar_emprestimos
      when "4"
        break
      else
        puts "Opção inválida. Tente novamente."
      end
    end
  end
end
