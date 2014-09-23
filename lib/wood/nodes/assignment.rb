module Wood::Nodes
  class Assignment < Node
    child_nodes :var, :value
    node_name   :assign
  end

  class AddAssignment < Assignment
    node_name   :add_assign
  end

  class SubAssignment < Assignment
    node_name   :sub_assign
  end

  class MulAssignment < Assignment
    node_name   :mul_assign
  end

  class DivAssignment < Assignment
    node_name   :div_assign
  end

  class BitwiseAndAssignment < Assignment
    node_name   :band_assign
  end

  class BitwiseNotAssignment < Assignment
    node_name   :bnot_assign
  end

  class BitwiseXORAssignment < Assignment
    node_name   :xor_assign
  end
end
