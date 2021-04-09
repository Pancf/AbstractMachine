
class Number < Struct.new(:value)

  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    false
  end

end

class Boolean < Struct.new(:value)

  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    false
  end

end

class Variable < Struct.new(:name)

  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    env[name]
  end

end

class Add < Struct.new(:left, :right)

  def to_s
    "#{left.to_s} + #{right.to_s}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Add.new(left.reduce(env), right)
    elsif right.reducible?
      Add.new(left, right.reduce(env))
    else
      Number.new(left.value + right.value)
    end
  end

end

class Multiply < Struct.new(:left, :right)

  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      Multiply.new(left.reduce(env), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(env))
    else
      Number.new(left.value * right.value)
    end
  end

end

class LessThan < Struct.new(:left, :right)

  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if left.reducible?
      LessThan.new(left.reduce(env), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(env))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class DoNothing
  def to_s
    "do-nothing"
  end

  def inspect
    "<<#{self}>>"
  end

  def ==(other_stmt)
    other_stmt.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if expression.reducible?
      [Assign.new(name, expression.reduce(env)), env]
    else
      [DoNothing.new, env.merge( { name => expression })]
    end
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) {#{consequence}} else {#{alternative}}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if condition.reducible?
      [If.new(condition.reduce(env), consequence, alternative), env]
    else
      case condition
      when Boolean.new(true)
        [consequence, env]
      when Boolean.new(false)
        [alternative, env]
      end
    end
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "while (#{condition}) {#{body}}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), env]
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(env)
    if first.instance_of?(DoNothing)
      [second, env]
    else
      reduced_first, reduced_env = first.reduce(env)
      [Sequence.new(reduced_first, second), reduced_env]
    end
  end
end

class Machine < Struct.new(:stmt, :env)

  def step
    self.stmt, self.env = stmt.reduce(env)
  end

  def run
    puts "#{stmt}, #{env}"
    while stmt.reducible?
      step
      puts "#{stmt}, #{env}"
    end
  end

end

