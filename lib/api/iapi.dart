abstract class IApi<T> {

  ///Recupera o elemento pelo id
  Future<T> getById(int id);

  ///Retorna todas as linhas
  Future<List<T>> getAll();

  ///Retorna o id da linha inserida
  Future<int> post(T body, {Map headers});

  ///Retorna o número de linhas afetadas
  Future<int> put(int id, {T body, Map headers});

  ///Retorna o número de linhas afetadas
  Future<int> patch(int id, {T body, Map headers});

  ///Retorna o número de linhas afetadas
  Future<int> delete(int id, {Map headers});

}
