using UnityEngine;

//http://haishibai.blogspot.com/2009/09/image-processing-c-tutorial-4-gaussian.html
public static class GaussianKernel
{
	public static float[] Calculate(double sigma, int size)
	{
		float[] ret = new float[size];
		double sum = 0;
		int half = size / 2;
		for (int i = 0; i < size; i++)
		{
			ret[i] = (float) (1 / (Mathf.Sqrt(2 * Mathf.PI) * sigma) * Mathf.Exp((float)(-(i - half) * (i - half) / (2 * sigma * sigma))));
			sum += ret[i];
		}
		return ret;
	}
}
