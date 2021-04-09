require_relative 'SmallstepSemantic'
class Number
  def evaluate(env)
    self
  end
end

class Boolean
  def evaluate(env)
    self
  end
end

class Variable
  def evaluate(env)
    env[name]
  end
end

class Add
  def evaluate(env)
    Number.new(left.evaluate(env).value + right.evaluate(env).value)
  end
end

class Multiply
  def evaluate(env)
    Number.new(left.evaluate(env).value * right.evaluate(env).value)
  end
end

class LessThan
  def evaluate(env)
    Boolean.new(left.evaluate(env).value < right.evaluate(env).value)
  end
end

class Assign
  def evaluate(env)
    env.merge({ name => expression.evaluate(env) })
  end
end

class DoNothing
  def evaluate(env)
    env
  end
end

class If
  def evaluate(env)
    case condition.evaluate(env)
    when Boolean.new(true)
      consequence.evaluate(env)
    when Boolean.new(false)
      alternative.evaluate(env)
    end
  end
end

class Sequence
  def evaluate(env)
    second.evaluate(first.evaluate(env))
  end
end

class While
  def evaluate(env)
    case condition.evaluate(env)
    when Boolean.new(true)
      evaluate(body.evaluate(env))
    when Boolean.new(false)
      env
    end
  end
end