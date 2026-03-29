double computeClosureScore(int targetScore) {
  return (targetScore * 0.90).ceilToDouble();
}

int getMaxAgents(int estimatedScore) {
  if (estimatedScore <= 8) {
    return 1;
  }
  if (estimatedScore <= 20) {
    return 2;
  }
  return 1;
}
