using UnityEngine;
public class Audio : MonoBehaviour
{
	AudioSource []_steps;
	AudioSource _step0;
	AudioSource _step1;

	const float _minPitch = .777f;
	const float _maxPitch = 1.333f;
	void Start()
	{
		_steps = GetComponents<AudioSource>();
		_step0 = _steps[0];
		_step1 = _steps[1];
	}
	float RandomPitch()
	{
		return Random.Range(_minPitch, _maxPitch);
	}
	public void Left()
	{
		PlayStep(true);
	}
	public void Right()
	{
		PlayStep(false);
	}
	void PlayStep(bool left)
	{
		_step0.pitch = _step1.pitch = RandomPitch();
		(left ? _step0 : _step1).Play();
	}
}
