export function processUserData(data: any) {  // Issue: 'any' type
  const apiKey = "sk-test-12345";  // Issue: Hardcoded secret
  
  // Issue: No null check
  const result = data.userId.toString();
  
  return result;
}

export async function fetchUser(id: string) {
  // Issue: No error handling
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}