require 'json'
require_relative 'user'
require_relative 'book'

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
    puts "\n--- BUSCAR LIVRO PARA REMOÇÃO ---"
    livros_encontrados = buscar_livro_por_nome
    
    if livros_encontrados.nil? || livros_encontrados.empty?
      puts "\n===== TODOS OS LIVROS ====="
      @books.each { |b| puts "ID: #{b.id} | Título: #{b.titulo} | Autor: #{b.autor}" }
    end
    
    print "\nDigite o ID do livro que deseja remover: "
    id = gets.chomp.to_i
    livro = @books.find { |b| b.id == id }
    
    if livro
      @books.delete(livro)
      puts "Livro '#{livro.titulo}' removido com sucesso!"
    else
      puts "ID inválido ou livro não encontrado."
    end
  end

  def listar_livros
    if @books.empty?
      puts "Nenhum livro cadastrado!"
    else
      puts "\n===== LIVROS ====="
      @books.each do |book|
        puts "ID: #{book.id} | #{book.titulo} (#{book.autor}) - #{book.disponivel ? 'Disponível' : 'Emprestado'}"
      end
    end
  end

  def buscar_livro_por_nome
    print "Digite parte do título para buscar: "
    termo = gets.chomp.downcase
    livros_encontrados = @books.select { |b| b.titulo.downcase.include?(termo) }
    
    if livros_encontrados.any?
      puts "\nLivros encontrados:"
      livros_encontrados.each { |b| puts "ID: #{b.id} | Título: #{b.titulo} | Autor: #{b.autor}" }
      return livros_encontrados # Retorna array de livros para reutilização
    else
      puts "Nenhum livro encontrado com '#{termo}'."
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
        puts "ID: #{user.id} | Nome: #{user.nome} | Email: #{user.email}"
      end
    end
  end

  def remover_usuario
    puts "\n--- BUSCAR USUÁRIO PARA REMOÇÃO ---"
    usuarios_encontrados = buscar_usuario_por_nome 
  
    if usuarios_encontrados.nil? || usuarios_encontrados.empty?
      listar_usuarios
    end
  
    print "\nDigite o ID do usuário que deseja remover: "
    id = gets.chomp.to_i
    usuario = @users.find { |u| u.id == id }
  
    if usuario
      @users.delete(usuario)
      puts "Usuário '#{usuario.nome}' removido com sucesso!"
    else
      puts "ID inválido ou usuário não encontrado."
    end
  end

  def buscar_usuario_por_nome
    print "Digite parte do nome para buscar: "
    nome = gets.chomp.downcase
    usuarios_encontrados = @users.select { |u| u.nome.downcase.include?(nome) }
    
    if usuarios_encontrados.any?
      puts "\nUsuários encontrados:"
      usuarios_encontrados.each { |u| puts "ID: #{u.id} | Nome: #{u.nome} | Email: #{u.email}" }
      return usuarios_encontrados 
    else
      puts "Nenhum usuário encontrado com '#{nome}'."
      nil
    end
  end

  def listar_livros_disponiveis
    puts "\n=== LIVROS DISPONÍVEIS ==="
    disp = @books.select(&:disponivel)
    if disp.empty?
      puts "Nenhum livro disponível."
    else
      disp.each { |b| puts "#{b.id} - #{b.titulo} (#{b.autor})" }
    end
  end

  def emprestar_livro
    livros_disponiveis = @books.select(&:disponivel)
    if livros_disponiveis.empty?
      puts "Não há livros disponíveis para empréstimo no momento."
      return
    end
  
    if @users.empty?
      puts "Não há usuários cadastrados. Registre um usuário primeiro."
      return
    end
  
    listar_livros_disponiveis
    
    print "\nDigite o ID do livro para emprestar: "
    book_id = gets.chomp.to_i
    livro = @books.find { |b| b.id == book_id && b.disponivel }
  
    unless livro
      puts "\n Livro não encontrado ou indisponível."
      return
    end
  
    puts "\n=== BUSCAR USUÁRIOS POR NOME ==="
    buscar_usuario_por_nome

  
    print "\nDigite o ID do usuário: "
    user_id = gets.chomp.to_i
    usuario = @users.find { |u| u.id == user_id }
  
    unless usuario
      puts "\n Usuário não encontrado."
      return
    end
  
    livro.disponivel = false
    @loans << { 
      book_id: livro.id, 
      user_id: usuario.id,
    }
  
    puts "\n EMPRÉSTIMO REGISTRADO:"
    puts "Livro: #{livro.titulo} (ID: #{livro.id})"
    puts "Usuário: #{usuario.nome} (ID: #{usuario.id})"
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
        puts "Emprestado para: #{usuario.nome} (ID: #{usuario.id})"
        puts "---------------------------------"
      else
        puts "Empréstimo inválido ou dados corrompidos (Livro ID: #{loan[:book_id]}, Usuário ID: #{loan[:user_id]})"
      end
    end
  end

  def devolver_livro
    if @loans.empty?
      puts "Não há empréstimos ativos no momento."
      return  
    end
  
    listar_emprestimos
    
    print "\nDigite o ID do livro a devolver: "
    book_id = gets.chomp.to_i
    loan = @loans.find { |l| l[:book_id] == book_id }
    livro = @books.find { |b| b.id == book_id }
  
    if loan && livro
      livro.disponivel = true
      @loans.delete(loan)
      puts "\n Livro '#{livro.titulo}' devolvido com sucesso!"
    else
      puts "\n Empréstimo não encontrado para o ID informado."
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
      puts "3. Listar livros disponíveis"
      puts "4. Remover Livro"
      puts "5. Voltar ao Menu Principal"
      print "Escolha uma opção: "
      opcao = gets.chomp
  
      case opcao
      when "1"
        adicionar_livro
      when "2"
        listar_livros
      when "3"
        listar_livros_disponiveis
      when "4"
        remover_livro
      when "5"
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
