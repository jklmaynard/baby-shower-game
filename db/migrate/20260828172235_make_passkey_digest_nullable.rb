class MakePasskeyDigestNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :players, :passkey_digest, true
  end
end
