# "Swiss", RubyMotion Android SQLite by VirtualQ


# schema loader stuff
# i know it's rough but it works

class Object

  attr_accessor :current_schema

  # convenience methods

  def log(tag, str)
    Android::Util::Log.d(tag, str)
  end

  def puts(str)
    log "general", str
  end

  def current_schema
    @current_schema
  end

  def schema(schema_name, &block)
    puts "running schema for #{schema_name}"
    @current_schema = {}
    @database_name = schema_name
    block.call
    puts @current_schema.inspect
  end

  def entity(class_name, opts={}, &block)
    # set default opts and merge passed in opts
    @opts = { id: true }.merge opts
    table_name = class_name.tableize
    puts "adding entity #{table_name} to schema"
    @table_name = table_name
    @current_schema[@table_name] = {}
    block.call
    ensure_primary_key
    $current_schema = @current_schema
    DataStore.current_schema = @current_schema
  end

  def ensure_primary_key
    # Check that the schema has one and only one primary key somewhere
    table_schema = @current_schema[@table_name]
    valid_table = false
    if @opts[:id]
      table_schema['id'] = 'INTEGER PRIMARY KEY AUTOINCREMENT' unless table_schema.has_key? 'id'
    else
      primary_keys = table_schema.values.select{ |val| val.include? 'PRIMARY KEY' }
      raise_primary_keys_error(table_schema.keys) unless primary_keys.length == 1
    end
  end

  def add_column(name, type)
    if @opts[:id] && name == 'id'
      raise_id_error unless type == 'INTEGER'
      type << ' PRIMARY KEY AUTOINCREMENT'
    end
    @current_schema[@table_name][name] = type
  end

  %w(boolean float double integer datetime).each do |type|
    define_method(type) do |column_name, column_opts|
      column_opts ||= {}
      type = type.upcase
      type = add_primary(type, column_name) if column_opts[:primary_key]
      add_column column_name.to_s, type
    end
  end

  def string(column_name, column_opts={})
    type = 'VARCHAR'
    type = add_primary(type, column_name) if column_opts[:primary_key]
    add_column column_name.to_s, type
  end

  def integer32(column_name, column_opts={})
    type = 'INTEGER'
    type = add_primary(type, column_name) if column_opts[:primary_key]
    add_column column_name.to_s, type
  end

  def raise_id_error
    error_message = %Q(
Your schema defines a non integer `id` column for #{@table_name}.
If you do not wish to use the default id column, then you should
specify the `id: false` option.
)
    raise error_message
  end

  def raise_primary_keys_error(primary_keys)
    error_message = %Q(

Your schema specified `id: false` for #{@table_name} and therefore must
specify one primary key for this table. Instead you specified #{primary_keys.length}.

)
    error_message += "These are the keys you gave: #{primary_keys}\n" if primary_keys.length > 1
    raise error_message
  end

  def add_primary(type, name)
    if @opts[:id]
      puts "WARNING: ignoring primary_key: #{name} because `id` is the default primary key"
    else
      type << ' PRIMARY KEY'
      type << ' AUTOINCREMENT' if type == 'INTEGER PRIMARY KEY'
    end
    type
  end

end
