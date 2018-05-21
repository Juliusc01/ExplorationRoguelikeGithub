using ca.HenrySoftware.Rage;
using System.Collections;
using UnityEngine;
[RequireComponent(typeof(CanvasGroup))]
public class Hero : MonoBehaviour
{
	static int AnimatorWalk = Animator.StringToHash("Walk");
	static int AnimatorAttack = Animator.StringToHash("Attack");
	static int AnimatorFacing = Animator.StringToHash("Facing");
	public CanvasGroup GroupText;
	CanvasGroup _groupMob;
	Animator[] _controllers;
	void Awake()
	{
		_groupMob = GetComponent<CanvasGroup>();
		_controllers = GetComponentsInChildren<Animator>();
	}
	void Start()
	{
		_groupMob.alpha = 0f;
		GroupText.alpha = 0f;
		Begin();
	}
	void Begin()
	{
		Ease.GoAlpha(this, 0f, 1f, 1f, null, null, EaseType.Linear);
		Ease.Go(this, 0f, 1f, 1f, (p) => GroupText.alpha = p, Continue0, EaseType.Linear);
	}
	void Continue0()
	{
		Ease.Go(this, 1f, 0f, 1f, (p) => GroupText.alpha = p, Continue1, EaseType.Linear);
	}
	void Continue1()
	{
		StartCoroutine(Animate());
	}
	IEnumerator Animate()
	{
		yield return new WaitForSeconds(5f);
		while (true)
		{
			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetBool(AnimatorWalk, true);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetInteger(AnimatorFacing, 3);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetInteger(AnimatorFacing, 0);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetInteger(AnimatorFacing, 1);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetInteger(AnimatorFacing, 2);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetBool(AnimatorWalk, false);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetTrigger(AnimatorAttack);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetTrigger(AnimatorAttack);
			yield return new WaitForSeconds(1f);

			for (var i = 0; i < _controllers.Length; i++)
				_controllers[i].SetTrigger(AnimatorAttack);
			yield return new WaitForSeconds(5f);

			Ease.Go(this, 0f, 1f, 1f, (p) => GroupText.alpha = p, Finish, EaseType.Linear);
		}
	}
	void Finish()
	{
		StopAllCoroutines();
		Ease.GoAlpha(this, 1f, 0f, 1f, null, null, EaseType.Linear);
		Ease.Go(this, 1f, 0f, 1f, (p) => GroupText.alpha = p, Begin, EaseType.Linear);
	}
}
