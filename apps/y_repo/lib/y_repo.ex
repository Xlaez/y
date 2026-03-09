defmodule YRepo do
  defdelegate aggregate(queryable, aggregate, field, opts \\ []), to: YRepo.Repo
  defdelegate all(queryable, opts \\ []), to: YRepo.Repo
  defdelegate delete(struct_or_changeset, opts \\ []), to: YRepo.Repo
  defdelegate delete!(struct_or_changeset, opts \\ []), to: YRepo.Repo
  defdelegate get(queryable, id, opts \\ []), to: YRepo.Repo
  defdelegate get!(queryable, id, opts \\ []), to: YRepo.Repo
  defdelegate get_by(queryable, clauses, opts \\ []), to: YRepo.Repo
  defdelegate get_by!(queryable, clauses, opts \\ []), to: YRepo.Repo
  defdelegate insert(struct_or_changeset, opts \\ []), to: YRepo.Repo
  defdelegate insert!(struct_or_changeset, opts \\ []), to: YRepo.Repo
  defdelegate transaction(fun_or_multi, opts \\ []), to: YRepo.Repo
  defdelegate update(struct_or_changeset, opts \\ []), to: YRepo.Repo
  defdelegate update!(struct_or_changeset, opts \\ []), to: YRepo.Repo
end
