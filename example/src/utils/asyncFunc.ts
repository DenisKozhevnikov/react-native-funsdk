export const asyncFunc = async <T extends (...args: any) => Promise<any>>(
  params: Parameters<T>[0],
  func: T
): Promise<Awaited<ReturnType<T>>> => {
  try {
    console.log(`${func.name} params: `, params);
    const res = await func(params);

    console.log(`${func.name} res: `, res);
    return res;
  } catch (error) {
    console.log(`${func.name} error: `, error);
    throw error;
  }
};
